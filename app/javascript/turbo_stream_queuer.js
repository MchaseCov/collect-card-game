let streamCount = 0;

export default async function turboStreamQueue(event) {
  const seconds = (streamCount * 0.75);
  streamCount++;
  if (seconds) {
    // For some reason, Hotwire does not allow you to resume a paused before-stream-render event
    // (Although you CAN resume a paused before-render). This code block allows me to collect Turbo Stream HTML
    // and queue them to allow animations to proceed in order without interruption
    event.preventDefault();
    await new Promise((r) => setTimeout(r, (1000 * seconds)));
    const target = document.getElementById(event.target.target);
    target.innerHTML = '';
    target.appendChild(event.target.firstChild.content);
  }
  await new Promise((r) => setTimeout(r, (1000)));
  streamCount--;
}
