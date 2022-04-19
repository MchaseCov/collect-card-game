import html from 'components/htm_create_element';

const classList = 'text-right text-md absolute top-0 inset-x-0 inset-x-0 border-2 rounded bg-red-700 border-slate-900 select-none pointer-events-none';

export default ({ name }) => html`<div className=${classList}>${name}</div>`;