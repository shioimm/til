# パスワードの表示・非表示を切り替える

```haml
= f.password_field :password, autocomplete: "off", class: "form-control toggle-password"

%span#password-field-icon
  %i.fas.fa-eye#password-field-text= ' パスワードを表示する'

:javascript
  let icon = document.querySelector('#password-field-icon').children[0]
  let text = document.querySelector('#password-field-text')
  let input = document.querySelector('.toggle-password')

  icon.addEventListener('click', function() {
    if (icon.classList.value === 'fas fa-eye-slash') {
      icon.className = 'fas fa-eye'
      text.textContent = ' パスワードを表示する'
    } else {
      icon.className = 'fas fa-eye-slash'
      text.textContent = ' パスワードを表示しない'
    }

    if (input.getAttribute("type") == "password") {
      input.setAttribute("type", "text");
    } else {
      input.setAttribute("type", "password");
    }
  })
```
