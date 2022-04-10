// I believe I cannot access images unless i precompile, or link them in the body.. which defeats the purpose of this refactor.
export default function cardInBattleTemplate(card, cardConstantData, keywords) {
    return `
    <div class='relative text-white border-2 border-black rounded-full w-36 h-52 mx-2.5 card-on-board min-w-36 has-tooltip' >
      <div id="attack" class="absolute bottom-0 z-10 w-12 h-12 pb-1 mt-1 text-4xl text-center text-white bg-red-500 border-2 border-red-600 rounded-full pointer-events-none select-none -left-2">${card.attack}</div>
      <div id="health" class="absolute bottom-0 z-10 w-12 h-12 pb-1 mt-1 text-4xl text-center border-2 rounded-full pointer-events-none select-none health-current border-lime-600 bg-lime-500 -right-2">${card.health}</div>
      <div id="art" class="w-full h-full overflow-hidden rounded-full pointer-events-none select-none">
    </div>
    </div>
    `;
  }
  
  // This is where things get complicated, as I need to account for 'nested divs' that are compiled from other sources.
  
  /* <% decorator = card.decorate.new(card)%>
  <%= content_tag :div,
                  id: local_assigns[:id],
                  data: (decorator.method(local_assigns[:decorator_data_method]).call if local_assigns[:decorator_data_method]),
                  class: 'relative text-white border-2 border-black rounded-full w-36 h-52 mx-2.5 card-on-board min-w-36 has-tooltip ' + local_assigns[:class],
                  draggable: local_assigns[:draggable] do %>
    <div id="attack" class="absolute bottom-0 z-10 w-12 h-12 pb-1 mt-1 text-4xl text-center text-white bg-red-500 border-2 border-red-600 rounded-full pointer-events-none select-none -left-2">
      <%=card.attack%>
    </div>
    <div id="health" class="absolute bottom-0 z-10 w-12 h-12 pb-1 mt-1 text-4xl text-center border-2 rounded-full pointer-events-none select-none health-current border-lime-600 bg-lime-500 -right-2">
      <%=card.health%>
    </div>
    <div id="art" class="w-full h-full overflow-hidden rounded-full pointer-events-none select-none">
      <%=image_tag('cardplaceholder.webp', class:"object-contain w-40 h-auto select-none pointer-events-none", draggable:"false")%>
    </div>
    <%=render(card,
           locals: { class: 'tooltip top-0 -left-44 z-50 shadow-2xl shadow-cyan-200', id: "card_#{card.id}_tooltip"},
           cached: true ) %>
  <% end %>
  <%= content_tag :div,
                  '',
                  class: ("opacity-50 rounded-full board-space" if local_assigns[:first_person_pov]),
                  data: decorator.board_space_data(local_assigns[:first_person_pov] || false) %> */
  