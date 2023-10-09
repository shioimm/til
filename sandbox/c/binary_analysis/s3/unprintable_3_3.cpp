// はじめて学ぶバイナリ解析 不正なコード型コンピュータを守るサイバーセキュリティ技術
#include<iostream>
#include<string>

int main(){
  std::string input;
  std::cin >> input;

  if (input == "\x01\x02\x03\x04\x05") { // 印字不可能文字
    std::cout << "success" << std::endl;
  } else {
    std::cout << "fail" << std::endl;
  }

  return 0;
}

// $ echo -e "\x01\x02\x03\x04\x05" | ./a.out
// success
