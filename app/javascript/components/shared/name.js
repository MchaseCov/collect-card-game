import html from 'components/htm_create_element';

const classList = (color) => `text-right text-sm absolute top-0 inset-x-0 inset-x-0 border-2 rounded border-slate-900 select-none pointer-events-none ${color}`;

export default (props) => html`<div className=${classList(props.classColor)}>${props.name}</div>`;