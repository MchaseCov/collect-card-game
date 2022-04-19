import html from 'components/htm_create_element';

export default function Art({ rounded }) {
  const isRounded = rounded ? 'rounded-full' : '';
  return html`
    <div id="art" className="w-full h-full overflow-hidden pointer-events-none select-none ${isRounded}">
        <img src=${temporaryImagePath} className="object-contain w-40 h-auto pointer-events-none select-none" draggable="false" />
    </div>
  `;
}
