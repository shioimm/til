### label以外の値で検索したい
- getOptionValueを使う
```js
const options = [
  { label: "Test A", id: 1 },
  { label: "Test B", id: 2 },
  { label: "Test C", id: 3 },
]x;

const OptionsSelect: React.FC<Props> = (props) => {
  const {
    options
  } = props

  return (
    <Select
      placeholder='Select...'
      options={options}
      getOptionValue={(option: { id: number }) => option.id}
      // ...
```
