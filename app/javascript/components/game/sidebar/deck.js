import html from "../../htm_create_element";


const Deck = (props) => {
  if(props.cardsInDeck <= 0 ){
    return html`
  <div className="deck" >
  <div className="deck-bottom deck-empty" ></div>
  </div>
`
  } else {
  const deckMaxHeight = 70
  const deckProportionalHeight = (props.cardsInDeck / 30 )
  let deckHeight = Math.round(deckMaxHeight * deckProportionalHeight)
  if (deckHeight % 2  != 0) deckHeight = 2 * Math.round(deckHeight/ 2);
  const halfHeight = Math.round(deckHeight/2)



  const deckFrontStyle = {
    height: `${deckHeight}px`,
    width: `180px`,
    bottom: '0px',
    transform: `rotateX( 90deg) translateZ(-${halfHeight}px)`
  };

  const deckLeftStyle = {
    height: `250px`,
    width: `${deckHeight}px`,
    transform: `rotateY( 90deg) translateZ(-${halfHeight}px)`,
  };

  const deckTopStyle = {
    height: `250px`,
    width: `180px`,
    transform: `rotateY(0deg) translateZ(${halfHeight}px)`
  };


  return html`
  <div className="deck has-tooltip" >
  <div className="top-0 bottom-0 px-3 py-1 mx-auto my-auto text-center bg-white -left-60 tooltip w-max h-max rounded-xl">
      Cards remaining in deck: ${props.cardsInDeck}
</div>
  <div className="deck-face deck-front" style=${deckFrontStyle}  ></div>
  <div className="deck-face deck-left"  style=${deckLeftStyle}  ></div>
  <div className="deck-face deck-top"   style=${deckTopStyle}  ></div>
  <div className="deck-face deck-bottom" ></div>
  </div>
  `

}
}

export default Deck

/*

*/