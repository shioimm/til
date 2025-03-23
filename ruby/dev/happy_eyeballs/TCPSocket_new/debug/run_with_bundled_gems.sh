#!/bin/bash

BUILD_DIR="../src/build"
MAX_RUNS=100
SUCCESS_COUNT=0
TEST_COMMAND="make test-bundled-gems BUNDLED_GEMS=drb"

pushd "$BUILD_DIR" > /dev/null || exit 1

for ((i = 1; i <= MAX_RUNS; i++)); do
    echo "Run #$i: $TEST_COMMAND"

    $TEST_COMMAND
    EXIT_CODE=$?

    if [ $EXIT_CODE -ne 0 ]; then
        echo "Error detected on run #$i (exit code: $EXIT_CODE)"
        popd > /dev/null || exit 1
        exit 1
    fi

    SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
done

popd > /dev/null || exit 1

echo "All $MAX_RUNS runs completed successfully."
exit 0
