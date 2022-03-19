const puppeteer = require('puppeteer');
const chai = require('chai');
const chaiFiles = require('chai-files');

chai.use(chaiFiles);
let expect = chai.expect;
let file = chaiFiles.file;

(async () => {
  try {
    const browser = await puppeteer.launch(
      // {args: ['--no-sandbox', '--disable-setuid-sandbox']}
    );
    const page = await browser.newPage();
    console.log(await browser.userAgent());
    await page.goto('https://example.com');
    await page.waitForXPath(
      '//*[contains(text(),"Example")]',
      {timeout: 3000})
    ;
    await page.screenshot({ path: 'example.png' });
    expect(file('example.png')).to.exist;
    await browser.close();
  } catch (e) {
    console.log(e);
    process.exit(1)
  }
})();