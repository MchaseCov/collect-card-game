const OpponentCardInHandContainer = document.getElementById('op-cards-hand');
const OpponentCardInHandTooltipClassList = 'left-0 right-0 text-center tooltip -bottom-10';
const OpponentCardInHandClassList = 'relative inline-block w-40 -mt-12 -ml-10 text-white border-2 border-black rounded h-60 max-h-60 bg-slate-700';

export default function createOpponentCardsHand(handData) {
  const opCardHandElements = handData.map((card) => createOpponentCardInHandElement(card));
  createOpponenntCardInHandElementTooltip(opCardHandElements.length);
  OpponentCardInHandContainer.append(...opCardHandElements);
}

function createOpponenntCardInHandElementTooltip(count) {
  const presentPlural = count === 1 ? '' : 's';
  const tooltipEl = document.createElement('div');
  tooltipEl.classList = OpponentCardInHandTooltipClassList;
  tooltipEl.innerText = `Your opponent has ${count} card${presentPlural} in hand.`;
  OpponentCardInHandContainer.append(tooltipEl);
}

function createOpponentCardInHandElement(card) {
  const cardEl = document.createElement('div');
  cardEl.classList = OpponentCardInHandClassList;
  cardEl.dataset.id = card.id;
  return cardEl;
}
