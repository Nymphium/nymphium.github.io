import * as pdfjsLib from 'https://cdn.jsdelivr.net/npm/pdfjs-dist@5.4.149/build/pdf.min.mjs';
import * as pdfjsViewer from 'https://cdn.jsdelivr.net/npm/pdfjs-dist@5.4.149/web/pdf_viewer.mjs';

pdfjsLib.GlobalWorkerOptions.workerSrc = 'https://cdn.jsdelivr.net/npm/pdfjs-dist@5.4.149/build/pdf.worker.min.mjs';

const container = document.getElementById('viewerContainer');

const eventBus = new pdfjsViewer.EventBus();
const pdfViewer = new pdfjsViewer.PDFSinglePageViewer({
  container: container,
  eventBus: eventBus,
});

const article = document.querySelector('.post');
const setViewerWidth = async () => {
  const pdfDoc = await pdfViewer.pdfDocument.getPage(1);
  const viewport = pdfDoc.getViewport({scale: 1})

  pdfViewer.currentScaleValue = article.clientWidth / viewport.width;
  document.getElementById('viewer').style = `--scale-factor: ${pdfViewer.currentScale};`;
};

const setup = () => {
  const params = new URLSearchParams(window.location.search);
  const specifiedPage = parseInt(params.get('page'), 10);

  eventBus.on('pagesinit', async () => {
    await setViewerWidth();

    const pdfDoc = await pdfViewer.pdfDocument.getPage(1);
    const viewport = pdfDoc.getViewport({scale: pdfViewer.currentScale});

    container.style.height = `${viewport.height}px`;

    if (specifiedPage && specifiedPage > 0 && specifiedPage <= pdfViewer.pagesCount) {
      pdfViewer.currentPageNumber = specifiedPage;
    }
  });

  eventBus.on('pagerendered', () => {
    const links = document.querySelectorAll('.page .annotationLayer a');
    links.forEach(link => {
      if (link.href.startsWith('http')) {
        link.target = '_blank';
        link.rel = 'noopener noreferrer';
      }
    });
  });
}

const setupNavigation = () => {
  const prevButton = document.getElementById('prev-page');
  const nextButton = document.getElementById('next-page');

  eventBus.on('pagechanging', (e) => {
    const progress = ((e.pageNumber - 1) / (pdfViewer.pagesCount - 1)) * 100;
    progressBar.style.width = `${progress}%`;

    const url = new URL(window.location);
    history.replaceState({page: e.pageNumber}, '', url);
  });

  prevButton.addEventListener('click', () => pdfViewer.previousPage());
  nextButton.addEventListener('click', () => pdfViewer.nextPage());

  document.addEventListener('keydown', (e) => {
    if (e.key === 'ArrowLeft') {
      pdfViewer.previousPage();
    } else if (e.key === 'ArrowRight') {
      pdfViewer.nextPage();
    }
  });

  const progressBar = document.getElementById('progress');
  const progressBarContainer = progressBar.parentElement;

  const getPageFromX = (x) => {
    const { left, width } = progressBarContainer.getBoundingClientRect();
    const page = Math.round(((x - left) / width) * (pdfViewer.pagesCount - 1)) + 1;
    return Math.max(1, Math.min(page, pdfViewer.pagesCount));
  };

  progressBarContainer.addEventListener('click', (e) => {
    pdfViewer.currentPageNumber = getPageFromX(e.clientX);
  });

  let isDragging = false;
  progressBarContainer.addEventListener('mousedown', () => isDragging = true);
  progressBarContainer.addEventListener('mouseup', () => isDragging = false);
  progressBarContainer.addEventListener('mouseleave', () => isDragging = false);
  progressBarContainer.addEventListener('mousemove', (e) => {
    if (isDragging) {
      pdfViewer.currentPageNumber = getPageFromX(e.clientX);
    }
  });
}

const setupSwipe = () => {
  // --- swipe to send pages
  let touchStartX = 0;
  let touchStartY = 0;
  const swipeThreshold = 50; // Minimum horizontal distance for a swipe

  const handleSwipe = (endX, endY) => {
    const deltaX = endX - touchStartX;
    const deltaY = endY - touchStartY;

    // Ensure it's a horizontal swipe and not a vertical scroll
    if (Math.abs(deltaX) > swipeThreshold && Math.abs(deltaX) > Math.abs(deltaY)) {
      if (deltaX < 0) {
        // Swiped Left: Go to the next page
        pdfViewer.nextPage();
      } else {
        // Swiped Right: Go to the previous page
        pdfViewer.previousPage();
      }
    }
  }

  container.addEventListener('touchstart', (e) => {
    // Record the starting coordinates of the touch
    touchStartX = e.changedTouches[0].screenX;
    touchStartY = e.changedTouches[0].screenY;
  }, { passive: true });

  container.addEventListener('touchend', (e) => {
    // Record the ending coordinates
    const touchEndX = e.changedTouches[0].screenX;
    const touchEndY = e.changedTouches[0].screenY;

    handleSwipe(touchEndX, touchEndY);
  }, { passive: true });
}

const setupResizeFullscreen = () => {
  const fullscreenButton = document.getElementById('fullscreen-button');
  let resizeTimer;

  window.addEventListener('resize', function() {
    if (document.fullscreenElement) {
      return
    }

    clearTimeout(resizeTimer);

    resizeTimer = setTimeout(setViewerWidth , 100);
  });

  fullscreenButton.addEventListener('click', () => {
    if (container.requestFullscreen) {
      container.requestFullscreen();
    } else if (container.mozRequestFullScreen) {
      container.mozRequestFullScreen();
    } else if (container.webkitRequestFullscreen) {
      container.webkitRequestFullscreen();
    } else if (container.msRequestFullscreen) {
      container.msRequestFullscreen();
    }
  });

  document.addEventListener('fullscreenchange', async () => {
    if (!document.fullscreenElement) {
      return
    }
    pdfViewer.currentScaleValue = 'page-fit';
  });
}

export function initializePDFViewer(path) {
  pdfjsLib.getDocument(path).promise.then(pdfDoc => {
    pdfViewer.setDocument(pdfDoc);
  });

  setup();
  setupNavigation();
  setupSwipe();
  setupResizeFullscreen();
}
