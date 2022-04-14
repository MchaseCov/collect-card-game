import html from '../../components/htm_create_element';

export default function CreateBlankSpace(props) {
  if (props.playerSpecificData) { props.playerSpecificData['data-gameplay-drag-board-target-param'] = props.position; }
  return html`<div data-board-id=${props.position} ...${props.playerSpecificData}></div>`;
}
