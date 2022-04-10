const friendlyBattlefield = document.getElementById('fp-cards-battle')
const opponentBattlefield = document.getElementById('op-cards-battle')

import cardInBattleTemplate from "./templates/card_in_battle"

const friendlyCardBoardBattleLocals = card => {
    return {
    classList: 'hover:ring-offset-2 hover:ring-offset-lime-300 board-animatable z-40 ring ring-lime-500 ',
    dataset: {
    styleCardsTarget: 'boardMinion',
    gameplayDragTarget: 'recievesPlayerInput friendlyActor',
    id: card.id,
    status: card.status,
    healthCurrent: card.health,
    healthCap: card.health_cap,
    gameplayDragActionParam: 'combat',
    action: 'dragstart->gameplay-drag#dragStart dragend->gameplay-drag#dragEnd drop->gameplay-drag#drop dragenter->gameplay-drag#dragEnter dragover->gameplay-drag#dragOver dragend->gameplay-drag#dragEnd'
    },
    draggable: true
}}

export default function createBattlefieldCards(jsonData){
    const fpCards = jsonData.player.cards.in_battlefield
    const opCards = jsonData.opponent.cards.in_battlefield
    const cardsToCreate = [
        { 
            cards: fpCards,
            battlefield: friendlyBattlefield,
            locals: friendlyCardBoardBattleLocals
        }
    ]
    cardsToCreate.forEach((cardObject) => createCardOnBoard(cardObject, jsonData))
}

function createCardOnBoard(cardObject, jsonData){
    cardObject.cards.forEach((card) => {
        const cardData = cardObject.locals(card)
        const cardConstantData = jsonData.card_constant_data[jsonData.card_constant_data.findIndex( c => c.id == card.card_constant_id)]
        const keywords = jsonData.card_keywords.filter( c => c.card_constant_id == card.card_constant_id )
        const templateHTML  = cardInBattleTemplate(card, cardConstantData, keywords).trim();
        const template = document.createElement('template');
        template.innerHTML = templateHTML
        const cardElement = template.content.firstChild
        //const cardElement = document.createElement("div");
        cardElement.classList += cardData.classList
        cardElement.draggable = cardData.draggable
        Object.keys(cardData.dataset).forEach(key => cardElement.dataset[key] = cardData.dataset[key]);
        cardObject.battlefield.appendChild(cardElement )
    })

}
