import html from '../../components/htm_create_element';

export default function CreateBlankSpace(card, playerSpecificData) {
  if (playerSpecificData) { playerSpecificData['data-gameplay-drag-board-target-param'] = card.position; }
  return html`<div data-board-id=${card.position} ...${playerSpecificData}></div>`;
}
