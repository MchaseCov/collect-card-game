import html from 'components/htm_create_element';

export default (props) => html`<p class="break-normal"><strong>${props.type}</strong>: ${props.body_text}</p>`;