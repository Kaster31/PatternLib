##Information
### English
To register a template, use - registerPattern(template name, description, return function)
To get the template text, use-getPatternKey(template name)

To start, we connect the library
```local Pattern = require('Pattern')```

Registering the template
```Pattern.registerPattern('test','Test Pattern',function()
    return 'Its Test Pattern'
end)
```

Now if we use it, it will return us 'Its Test Pattern'

We get information about the template that was originally intended for use in Imgui. Maybe you will find another use.

```local getKey = getPatternKey('test') returns 'Its Test Pattern'.```

If you need to use one template in several scripts, then there is a template autoloading system for this. Create a lua script in the moonloader/Pattern folder.
The library will load it automatically.

### Russian
Для регистрации шаблона используется - registerPattern(название шаблона, описание, функция возврата)
Для получения текста шаблона используется - getPatternKey(название шаблона)

Для начала подключаем библиотеку
```local Pattern = require('Pattern')```

Регистрируем шаблон
```Pattern.registerPattern('test','Test Pattern',function()
    return 'Its Test Pattern'
end)
```

Теперь если мы используем его, то он вернёт нам  'Its Test Pattern'

Получаем информацию о шаблоне, изначально предназначалось для использования в Imgui. Может найдёте и другое применение.

```local getKey = getPatternKey('test') вернёт  'Its Test Pattern'.```

Если вам нужно использовать один шаблон в нескольких скриптах, то для этого есть система автозагрузки шаблона. Создаёте lua скрипт в папке moonloader/Pattern.
Библиотека автоматически загрузит его.
