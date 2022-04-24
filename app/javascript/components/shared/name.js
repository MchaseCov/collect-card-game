import html from 'components/htm_create_element';

const classList = (color) => `text-right text-sm absolute top-0 inset-x-0 inset-x-0 border-b-2 rounded-b-md border-blackish select-none pointer-events-none w-full pr-1 ${color}`;

export default (props) => html`<div className=${classList(props.classColor)}>${props.name}</div>`;