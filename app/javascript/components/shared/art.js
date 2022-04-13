import html from 'components/htm_create_element';

export default function Art({ rounded }) {
  const isRounded = rounded ? 'rounded-full' : '';
  return html`
    <div id="art" class="w-full h-full overflow-hidden pointer-events-none select-none ${isRounded}">
        <img src=${temporaryImagePath} class="object-contain w-40 h-auto select-none pointer-events-none" draggable="false" />
    </div>
  `;
}
