let wasmInstance = null;
let wasmMemory = null;
let isWaitingForInput = false;

const registerNames = [
  "zero",
  "at",
  "v0",
  "v1",
  "a0",
  "a1",
  "a2",
  "a3",
  "t0",
  "t1",
  "t2",
  "t3",
  "t4",
  "t5",
  "t6",
  "t7",
  "s0",
  "s1",
  "s2",
  "s3",
  "s4",
  "s5",
  "s6",
  "s7",
  "t8",
  "t9",
  "k0",
  "k1",
  "gp",
  "sp",
  "fp",
  "ra",
];

async function loadWasm() {
  try {
    const result = await WebAssembly.instantiateStreaming(
      fetch("mipster.wasm"),
    );

    wasmInstance = result.instance;
    wasmMemory = wasmInstance.exports.memory;

    console.log("WASM loaded successfully");
    return true;
  } catch (error) {
    console.error("Failed to load WASM:", error);
    document.getElementById("output").textContent =
      "Error: Failed to load WASM module\n" + error.message;
    return false;
  }
}

function getStringFromWasm(ptr, len) {
  const bytes = new Uint8Array(wasmMemory.buffer, ptr, len);
  return new TextDecoder().decode(bytes);
}

function writeStringToWasm(str, ptr, maxLen) {
  const bytes = new TextEncoder().encode(str);
  const len = Math.min(bytes.length, maxLen);
  const memory = new Uint8Array(wasmMemory.buffer, ptr, len);
  memory.set(bytes.slice(0, len));
  return len;
}

function updateOutput() {
  const outputPtr = wasmInstance.exports.getOutputPtr();
  const outputLen = wasmInstance.exports.getOutputLen();

  if (outputLen > 0) {
    const output = getStringFromWasm(outputPtr, outputLen);
    document.getElementById("output").textContent += output;
    wasmInstance.exports.clearOutput();
  }
}

function updateRegisters() {
  const registersDiv = document.getElementById("registers");
  registersDiv.innerHTML = "";

  for (let i = 0; i < 32; i++) {
    const value = wasmInstance.exports.getRegister(i);
    const registerDiv = document.createElement("div");
    registerDiv.className = "register";
    registerDiv.innerHTML = `
            <div class="name">$${registerNames[i]} (${i})</div>
            <div class="value">0x${value.toString(16).padStart(8, "0")}</div>
        `;
    registersDiv.appendChild(registerDiv);
  }
}

function showInputPrompt() {
  document.getElementById("inputPrompt").style.display = "flex";
  document.getElementById("inputField").focus();
  isWaitingForInput = true;
}

function hideInputPrompt() {
  document.getElementById("inputPrompt").style.display = "none";
  document.getElementById("inputField").value = "";
  isWaitingForInput = false;
}

function submitInput() {
  const input = document.getElementById("inputField").value.trim();

  // append the input to output for display
  document.getElementById("output").textContent += input + "\n";

  const encoder = new TextEncoder();
  const inputBytes = encoder.encode(input);

  // write input to a known location in WASM memory
  const inputPtr = 2048; // use a different offset than code
  const memory = new Uint8Array(wasmMemory.buffer);
  memory.set(inputBytes, inputPtr);

  wasmInstance.exports.provideInput(inputPtr, inputBytes.length);

  hideInputPrompt();

  // continue execution after input
  console.log("Calling continueAfterInput()...");
  const result = wasmInstance.exports.continueAfterInput();
  console.log("continueAfterInput() returned:", result);

  updateOutput();

  const stillWaiting = wasmInstance.exports.isWaitingForInput();
  console.log("Still waiting for input?", stillWaiting);

  if (stillWaiting) {
    console.log("Showing input prompt again...");
    showInputPrompt();
  } else {
    console.log("Execution completed, updating registers");
    updateRegisters();
  }
}

async function runCode() {
  if (!wasmInstance) {
    document.getElementById("output").textContent =
      "Error: WASM not loaded yet\n";
    return;
  }

  const code = document.getElementById("editor").value;
  document.getElementById("output").textContent = "";

  try {
    // Encode the code to bytes
    const encoder = new TextEncoder();
    const codeBytes = encoder.encode(code);

    // allocate memory for the code
    // write it to a known location in WASM memory
    // for simplicity, let's use offset 4096
    const codePtr = 4096;
    const memory = new Uint8Array(wasmMemory.buffer);

    // make sure we have enough space
    if (codePtr + codeBytes.length > memory.length) {
      throw new Error("Code too large");
    }

    memory.set(codeBytes, codePtr);

    const result = wasmInstance.exports.run(codePtr, codeBytes.length);

    updateOutput();

    const waitingForInput = wasmInstance.exports.isWaitingForInput();
    console.log(
      "After run(), waiting for input?",
      waitingForInput,
      "result:",
      result,
    );

    if (waitingForInput) {
      console.log("Showing input prompt for first time...");
      showInputPrompt();
    } else {
      if (result === 0) {
        console.log("Program completed successfully");
        updateRegisters();
      } else if (result === -1) {
        console.log("Program had errors");
      }
    }
  } catch (error) {
    document.getElementById("output").textContent +=
      "\nError: " + error.message;
    console.error(error);
  }
}

function clearOutput() {
  document.getElementById("output").textContent = "";
}

document.addEventListener("DOMContentLoaded", async () => {
  const loadingOverlay = document.getElementById("loadingOverlay");

  const loaded = await loadWasm();

  if (loaded) {
    loadingOverlay.style.display = "none";

    updateRegisters();
  } else {
    loadingOverlay.querySelector("p").textContent =
      "Failed to load WASM module";
    setTimeout(() => {
      loadingOverlay.style.display = "none";
    }, 2000);
  }

  document.getElementById("runBtn").addEventListener("click", runCode);
  document.getElementById("clearBtn").addEventListener("click", clearOutput);
  document.getElementById("submitInput").addEventListener("click", submitInput);

  document.getElementById("inputField").addEventListener("keypress", (e) => {
    if (e.key === "Enter") {
      submitInput();
    }
  });

  document.getElementById("editor").addEventListener("keydown", (e) => {
    if (e.ctrlKey && e.key === "Enter") {
      runCode();
    }
  });
});
