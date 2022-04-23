import html from 'components/htm_create_element';

const classList = (color) => `text-center text-xs absolute bottom-0 inset-x-0 select-none pointer-events-none h-4 ${color}`;

export default (props) => html`<div className=${classList(props.classColor)}>${props.tribe}</div>`;
