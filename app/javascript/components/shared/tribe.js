import html from 'components/htm_create_element';

const classList = 'text-center text-xs absolute bottom-0 inset-x-0 bg-red-700 select-none pointer-events-none h-4';

export default ({ tribe }) => html`<div class=${classList}>${tribe}</div>`;
