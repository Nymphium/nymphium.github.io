import * as pdfjsLib from 'https://cdn.jsdelivr.net/npm/pdfjs-dist@5.4.149/build/pdf.min.mjs';
import {
  EventBus,
  PDFLinkService,
  PDFSinglePageViewer,
} from 'https://cdn.jsdelivr.net/npm/pdfjs-dist@5.4.149/web/pdf_viewer.mjs';

pdfjsLib.GlobalWorkerOptions.workerSrc =
  'https://cdn.jsdelivr.net/npm/pdfjs-dist@5.4.149/build/pdf.worker.min.mjs';

class SlideViewer {
  #container;
  #eventBus;
  #linkService;
  #viewer;
  #progressBar;
  #progressBarContainer;
  #baseViewport = null;
  #isDragging = false;

  constructor(pdfPath) {
    this.#container = document.getElementById('viewerContainer');
    this.#progressBar = document.getElementById('progress');
    this.#progressBarContainer = this.#progressBar.parentElement;

    this.#eventBus = new EventBus();
    this.#linkService = new PDFLinkService({ eventBus: this.#eventBus });
    this.#viewer = new PDFSinglePageViewer({
      container: this.#container,
      eventBus: this.#eventBus,
      linkService: this.#linkService,
    });
    this.#linkService.setViewer(this.#viewer);

    this.#setupEvents();
    this.#setupNavigation();
    this.#setupSwipe();
    this.#setupResizeFullscreen();
    this.#loadDocument(pdfPath);
  }

  async #loadDocument(path) {
    const pdfDoc = await pdfjsLib.getDocument(path).promise;
    this.#viewer.setDocument(pdfDoc);
    this.#linkService.setDocument(pdfDoc, null);
  }

  #fitToWidth() {
    const article = document.querySelector('.post');
    this.#viewer.currentScaleValue = article.clientWidth / this.#baseViewport.width;
    document.getElementById('viewer').style = `--scale-factor: ${this.#viewer.currentScale};`;
    const height = this.#baseViewport.height * this.#viewer.currentScale;
    this.#container.style.height = `${height}px`;
    this.#container.parentElement.style.height = `${height}px`;
    this.#viewer.update();
  }

  #updateProgressBar(pageNumber) {
    const pagesCount = this.#viewer.pagesCount;
    const progress = pagesCount > 1
      ? ((pageNumber - 1) / (pagesCount - 1)) * 100
      : 0;
    this.#progressBar.style.width = `${progress}%`;

    this.#progressBarContainer.setAttribute('aria-valuenow', pageNumber);
    this.#progressBarContainer.setAttribute('aria-valuemax', pagesCount);
  }

  #setupEvents() {
    const params = new URLSearchParams(window.location.search);
    const specifiedPage = parseInt(params.get('page'), 10);

    this.#eventBus.on('pagesinit', async () => {
      const page = await this.#viewer.pdfDocument.getPage(1);
      this.#baseViewport = page.getViewport({ scale: 1 });

      this.#fitToWidth();

      if (specifiedPage > 0 && specifiedPage <= this.#viewer.pagesCount) {
        this.#viewer.currentPageNumber = specifiedPage;
      }


      this.#updateProgressBar(this.#viewer.currentPageNumber);
    });

    this.#eventBus.on('pagerendered', () => {
      const links = document.querySelectorAll('.page .annotationLayer a');
      links.forEach(link => {
        if (link.href.startsWith('http')) {
          link.target = '_blank';
          link.rel = 'noopener noreferrer';
        }
      });
    });

    this.#eventBus.on('pagechanging', (e) => {
      this.#updateProgressBar(e.pageNumber);


      const url = new URL(window.location);
      url.searchParams.set('page', e.pageNumber);
      history.replaceState({ page: e.pageNumber }, '', url);
    });
  }

  #setupNavigation() {
    document.getElementById('prev-page')
      .addEventListener('click', () => this.#viewer.previousPage());
    document.getElementById('next-page')
      .addEventListener('click', () => this.#viewer.nextPage());

    document.addEventListener('keydown', (e) => {
      if (e.key === 'ArrowLeft') {
        this.#viewer.previousPage();
      } else if (e.key === 'ArrowRight') {
        this.#viewer.nextPage();
      }
    });

    this.#progressBarContainer.addEventListener('click', (e) => {
      this.#viewer.currentPageNumber = this.#getPageFromX(e.clientX);
    });

    this.#progressBarContainer.addEventListener('mousedown', () => {
      this.#isDragging = true;
    });

    document.addEventListener('mouseup', () => {
      this.#isDragging = false;
    });

    document.addEventListener('mousemove', (e) => {
      if (this.#isDragging) {
        this.#viewer.currentPageNumber = this.#getPageFromX(e.clientX);
      }
    });
  }

  #getPageFromX(x) {
    const { left, width } = this.#progressBarContainer.getBoundingClientRect();
    const page = Math.round(((x - left) / width) * (this.#viewer.pagesCount - 1)) + 1;
    return Math.max(1, Math.min(page, this.#viewer.pagesCount));
  }

  #setupSwipe() {
    let touchStartX = 0;
    let touchStartY = 0;
    const swipeThreshold = 50;

    this.#container.addEventListener('touchstart', (e) => {
      touchStartX = e.changedTouches[0].screenX;
      touchStartY = e.changedTouches[0].screenY;
    }, { passive: true });

    this.#container.addEventListener('touchend', (e) => {
      const endX = e.changedTouches[0].screenX;
      const endY = e.changedTouches[0].screenY;
      const deltaX = endX - touchStartX;
      const deltaY = endY - touchStartY;

      if (Math.abs(deltaX) > swipeThreshold && Math.abs(deltaX) > Math.abs(deltaY)) {
        if (deltaX < 0) {
          this.#viewer.nextPage();
        } else {
          this.#viewer.previousPage();
        }
      }
    }, { passive: true });
  }

  #setupResizeFullscreen() {
    let resizeTimer;

    window.addEventListener('resize', () => {
      if (document.fullscreenElement) return;
      clearTimeout(resizeTimer);
      resizeTimer = setTimeout(() => this.#fitToWidth(), 100);
    });

    document.getElementById('fullscreen-button')
      .addEventListener('click', () => this.#container.requestFullscreen());

    document.addEventListener('fullscreenchange', () => {
      if (document.fullscreenElement) {
        this.#viewer.currentScaleValue = 'page-fit';
      } else {
        this.#fitToWidth();
      }
    });
  }
}

export function initSlideViewer(path) {
  new SlideViewer(path);
}
