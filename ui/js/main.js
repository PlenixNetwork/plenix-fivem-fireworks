/**
 * Plenix FiveM Fireworks - Main JavaScript
 * Launch menu NUI
 */

const resourceName = typeof GetParentResourceName === 'function' ? GetParentResourceName() : 'plenix-fivem-fireworks';

// Debug mode (set from config on open)
let debugMode = false;

function debug(...args) {
    if (debugMode) {
        console.log('[Fireworks]', ...args);
    }
}

// State management
const state = {
    menuOpen: false,
    fireworks: [],
    categories: [],
    locale: {},
    selectedCategory: 'all',
    selectedKey: null,
    active: 0
};

const $ = (id) => document.getElementById(id);

/**
 * Post to a Lua NUI callback
 */
function post(name, data = {}) {
    return fetch(`https://${resourceName}/${name}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json; charset=UTF-8' },
        body: JSON.stringify(data)
    }).catch((err) => debug('Callback failed:', name, err));
}

/**
 * Bind event listeners
 */
document.addEventListener('DOMContentLoaded', () => {
    $('menu-close-btn').addEventListener('click', closeMenu);
    document.querySelector('.menu-overlay').addEventListener('click', closeMenu);

    $('launch-btn').addEventListener('click', launchSelected);
    $('stop-last-btn').addEventListener('click', () => post('stopLast'));
    $('stop-all-btn').addEventListener('click', () => post('stopAll'));

    // Links open in the player's browser; navigating inside NUI would replace the menu
    document.querySelectorAll('.external-link').forEach((link) => {
        link.addEventListener('click', (e) => {
            e.preventDefault();
            if (typeof window.invokeNative === 'function') {
                window.invokeNative('openUrl', link.href);
            }
        });
    });

    document.addEventListener('keydown', (e) => {
        if (!state.menuOpen) return;
        if (e.key === 'Escape') {
            closeMenu();
        } else if (e.key === 'Enter') {
            launchSelected();
        }
    });

    window.addEventListener('message', handleNUIMessage);
});

/**
 * Handle incoming NUI messages
 */
function handleNUIMessage(event) {
    const data = event.data;

    switch (data.action) {
        case 'openMenu':
            debugMode = !!data.debug;
            openMenu(data);
            break;

        case 'updateActive':
            setActive(data.count);
            break;
    }
}

/**
 * Open menu
 */
function openMenu(data) {
    state.fireworks = data.fireworks || [];
    state.categories = data.categories || [];
    state.locale = data.locale || {};
    state.selectedCategory = 'all';
    state.selectedKey = null;

    updateMenuLocale();
    renderCategories();
    renderFireworks();
    setActive(data.active || 0);

    state.menuOpen = true;
    $('menu-container').classList.remove('hidden');
    debug('Menu opened with', state.fireworks.length, 'fireworks');
}

/**
 * Close menu
 */
function closeMenu() {
    if (!state.menuOpen) return;
    state.menuOpen = false;
    $('menu-container').classList.add('hidden');
    post('closeMenu');
}

/**
 * Update menu with locale strings
 */
function updateMenuLocale() {
    const l = state.locale;
    $('menu-title').textContent = l.title || 'Fireworks';
    $('menu-select-label').textContent = l.select || 'Select a firework';
    $('launch-label').textContent = l.launch || 'Launch';
    $('stop-last-label').textContent = l.stopLast || 'Stop last';
    $('stop-all-label').textContent = l.stopAll || 'Stop all';
}

/**
 * Build a tab or card icon
 */
function icon(name) {
    const i = document.createElement('i');
    i.className = 'fas ' + (name || 'fa-rocket');
    return i;
}

function categoryIcon(key) {
    const category = state.categories.find((c) => c.key === key);
    return category ? category.icon : 'fa-rocket';
}

/**
 * Category tabs (only the categories that have fireworks)
 */
function renderCategories() {
    const tabs = $('category-tabs');
    tabs.innerHTML = '';

    const used = new Set(state.fireworks.map((f) => f.category));
    const list = [{ key: 'all', label: state.locale.all || 'All', icon: 'fa-layer-group' }]
        .concat(state.categories.filter((c) => used.has(c.key)));

    list.forEach((category) => {
        const tab = document.createElement('button');
        tab.className = 'category-tab' + (category.key === state.selectedCategory ? ' selected' : '');
        tab.appendChild(icon(category.icon));
        tab.appendChild(document.createTextNode(category.label));
        tab.addEventListener('click', () => {
            state.selectedCategory = category.key;
            renderCategories();
            renderFireworks();
        });
        tabs.appendChild(tab);
    });
}

/**
 * Firework cards for the selected category
 */
function renderFireworks() {
    const grid = $('firework-grid');
    grid.innerHTML = '';

    state.fireworks
        .filter((f) => state.selectedCategory === 'all' || f.category === state.selectedCategory)
        .forEach((firework) => {
            const item = document.createElement('div');
            item.className = 'firework-item' + (firework.key === state.selectedKey ? ' selected' : '');

            const image = document.createElement('div');
            image.className = 'firework-image';
            if (firework.image) {
                const img = document.createElement('img');
                img.src = firework.image;
                img.alt = '';
                img.addEventListener('error', () => image.replaceChildren(icon(categoryIcon(firework.category))));
                image.appendChild(img);
            } else {
                image.appendChild(icon(categoryIcon(firework.category)));
            }

            const name = document.createElement('div');
            name.className = 'firework-name';
            name.textContent = firework.name;

            const meta = document.createElement('div');
            meta.className = 'firework-meta';
            meta.textContent = `${firework.shoots} ${state.locale.shots || 'shots'} · ~${formatDuration(firework.duration)}`;

            item.append(image, name, meta);
            item.addEventListener('click', () => selectFirework(firework.key));
            item.addEventListener('dblclick', () => {
                selectFirework(firework.key);
                launchSelected();
            });
            grid.appendChild(item);
        });

    $('launch-btn').disabled = state.selectedKey === null;
}

function selectFirework(key) {
    state.selectedKey = key;
    renderFireworks();
}

/**
 * Launch the selected firework (the menu closes)
 */
function launchSelected() {
    if (state.selectedKey === null) return;

    state.menuOpen = false;
    $('menu-container').classList.add('hidden');
    post('launch', { key: state.selectedKey });
}

/**
 * Active firework count and the stop buttons
 */
function setActive(count) {
    state.active = count || 0;
    const template = state.locale.active || 'Active fireworks: %d';
    $('active-count').textContent = template.replace('%d', state.active);
    document.querySelector('.menu-status').classList.toggle('has-active', state.active > 0);
    $('stop-last-btn').disabled = state.active === 0;
    $('stop-all-btn').disabled = state.active === 0;
}

/**
 * 65000 -> "1m 05s", 9000 -> "9s"
 */
function formatDuration(ms) {
    const total = Math.max(1, Math.round(ms / 1000));
    const minutes = Math.floor(total / 60);
    const seconds = total % 60;
    return minutes > 0 ? `${minutes}m ${String(seconds).padStart(2, '0')}s` : `${seconds}s`;
}
