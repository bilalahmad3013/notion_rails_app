import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dataTableBody", "newRowTemplate", "newEntriesContainer", "addButton", "databaseId"]

  connect() {   
    this.template = this.newRowTemplateTarget.content.firstElementChild.cloneNode(true);    
  }

  addRow() {    
    this.addButtonTarget.disabled = true;
    const newRow = this.template.cloneNode(true);    
    newRow.querySelectorAll("input").forEach(input => {
      const name = input.name.replace("new_", "");
      const dataType = input.dataset.type;

      const hiddenInput = document.createElement("input");
      hiddenInput.type = "hidden";
      hiddenInput.name = `new_entries[${name}][]`;
      
      input.addEventListener("input", () => {        
        if (this.validateInput(input.value, dataType)) {
          hiddenInput.value = input.value;
          input.setCustomValidity("");
        } else {
          input.setCustomValidity(`Please enter a valid ${dataType}`);
          input.reportValidity();
        }
        this.processLastRowValues(newRow);
      });

      this.newEntriesContainerTarget.appendChild(hiddenInput);
      newRow.querySelector('#addRowBtn').disabled = true;
    });

    newRow.querySelector(".remove-row").addEventListener("click", () => {
      newRow.remove();
      this.addButtonTarget.disabled = false;
    });

    this.dataTableBodyTarget.appendChild(newRow);
  }

  processLastRowValues(newRow) {
    const lastRow = this.dataTableBodyTarget.lastElementChild;
    const rowInputs = newRow.querySelectorAll("input");
    const rowData = {};
    let allInputsValid = true;

    lastRow.querySelectorAll("input").forEach(input => {
      const columnName = input.name.replace("new_", "");
      rowData[columnName] = input.value;
    });

    rowInputs.forEach(input => {
      const dataType = input.dataset.type;
      if (!this.validateInput(input.value, dataType)) {
        allInputsValid = false;
      }
    });

    const addButton = newRow.querySelector('#addRowBtn');
    addButton.disabled = !allInputsValid;

    addButton.onclick = () => {
      this.handleAddRow(rowData, addButton);
    };
  }

  handleAddRow(rowData, addButton) {
    const databaseId = this.databaseIdTarget.value;
    const apiUrl = `/notion_database/create_in_notion?database_id=${databaseId}`;
    const meta = document.querySelector('meta[name=csrf-token]');
    const token = meta && meta.getAttribute('content');
    addButton.innerHTML = `<div class="spinner-border" role="status">                           
                          </div>`;
    fetch(apiUrl, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'text/html',
        'X-CSRF-Token': token,
      },
      body: JSON.stringify(rowData),
    })
    .then(response => {
      if (!response.ok) {
        throw new Error('Network response was not ok');
      }
      return response.json();
    })
    .then(data => {      
      if(data.response){        
        window.location.reload();
      }
    })
    .catch(error => {
      console.error("Error during API call:", error);
    });
  }  

  validateInput(value, dataType) {
    if (value.trim() === "") return false;
    
    if (dataType === "number") return !isNaN(value);
    if (dataType === "text") return /^[a-zA-Z\s]+$/.test(value);
    if (dataType === "date") return !isNaN(Date.parse(value));
    if (dataType === "email") return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value);
    
    return true;
  }
  
}
