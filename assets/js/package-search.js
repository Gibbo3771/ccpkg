document.addEventListener("DOMContentLoaded", () => {
  let idx;
  let masterfile;
  const searchBox = document.querySelector("#search");
  const searchResultList = document.querySelector("#search-result-list");

  const addRecord = (record) => {
    const listItem = document.createElement("tr");
    const {name, description} = record;
    const markup = `
    <td class="name">
      <a href="/f/${name}">${name}</a>
    </td>
    <td class="description">${description}</td>
    `;
    listItem.innerHTML = markup;
    searchResultList.appendChild(listItem);
  };

  const addAllRecords = () => {
    masterfile.forEach((record) => {
      addRecord(record);
    });
  }

  fetch("assets/masterfile.json")
    .then((r) => r.json())
    .then((m) => {
      masterfile = m;
      idx = lunr(function () {
        this.ref("name");
        this.field("name");

        masterfile.forEach(function (doc) {
          this.add(doc);
        }, this);
      });
    })
    .then(() => {
      addAllRecords();
    })
    .then(() => {
      searchBox.addEventListener("input", (evt) => {
        const value = evt.target.value;
        if (value && value.length > 0) {
          const results = idx.search(value);
          const packagesRecords = [];
          for (const result of results) {
            for (const r of masterfile) {
              if (r.name === result.ref) packagesRecords.push(r);
            }
          }
          searchResultList.innerHTML = "";
          packagesRecords.forEach((record) => {
            addRecord(record);
          });
        } else{
          addAllRecords();
        }
      });
    });
});
