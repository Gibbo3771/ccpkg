document.addEventListener("DOMContentLoaded", () => {
  const formulaBox = document.querySelector("#example-formula");
  if(!formulaBox) return;
  const url = "https://raw.githubusercontent.com/Gibbo3771/ccpkg/main/formula/ccpkg-hello-world.lua"
  fetch(url)
    .then((r) => r.text())
    .then((r) => {
      const hightlighted = hljs.highlight("lua", r);
      // A bit nasty but works
      // div > pre > code > parent > code
      formulaBox.childNodes[0].childNodes[0].childNodes[0].childNodes[0].parentElement.innerHTML = hightlighted.value
    });
});
