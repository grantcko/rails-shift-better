function show() {
  console.log("click");
  document.getElementById('sidebar').classList.toggle('active');
  // document.getElementById('sidebar').classList.toggle('active');
}

document.getElementById('toggle').addEventListener("click", show)
