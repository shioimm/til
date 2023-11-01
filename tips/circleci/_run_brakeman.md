# CircleCIでプッシュごとにBrakemanを実行する

```yml
# Gemfile

gem 'brakeman'
```

```yml
# .circleci/config.yml

commands:
  build:
    steps:
      ...

jobs:
  brakeman:
    executor: default
    steps:
      - build
      - run:
          name: run brakeman
          command: |
            bundle exec brakeman
  frontend-tests:
    ...
  backend-tests:
    ...

workflows:
  version: 2
  build_and_test:
    jobs:
      - brakeman
      - frontend-tests:
          requires:
            - lint
      - backend-tests:
          requires:
            - lint
```
