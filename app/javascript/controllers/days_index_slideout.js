function show() {
  console.log("click");
  document.getElementById('sidebar').classList.toggle('active');
  document.getElementById('manager-calendar').classList.toggle('justify-content-center');
  document.getElementById('manager-calendar').classList.toggle('justify-content-end');
}

document.getElementById('toggle').addEventListener("click", show)
