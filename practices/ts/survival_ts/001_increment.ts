// https://typescriptbook.jp/tutorials/make-a-simple-function-via-cli

function increment(num: number) {
  return num + 1;
}
 
console.log(increment(999));

// $ tsc practices/ts/survival_ts/001_increment.ts
// $ node practices/ts/survival_ts/001_increment.js