document.addEventListener("keydown", (e) => {

  switch (e.key.toLowerCase()) {

    case "f":
      if (!document.fullscreenElement)
        document.documentElement.requestFullscreen();
      else
        document.exitFullscreen();
      break;

    case "h":
      hudVisible = !hudVisible;
      break;

    case "0":
      resetScene();
      break;
  }
});
