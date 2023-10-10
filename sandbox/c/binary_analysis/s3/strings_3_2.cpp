// はじめて学ぶバイナリ解析 不正なコード型コンピュータを守るサイバーセキュリティ技術
#include<iostream>
#include<string>

int main(){
  std::string input;
  std::cin >> input;

  if (input == "secret_key") {
    std::cout << "success" << std::endl;
  } else {
    std::cout << "fail" << std::endl;
  }

  return 0;
}

// $ strings a.out | grep ^[^_.]
// ...
// secret_key
// success
// fail
// ...
