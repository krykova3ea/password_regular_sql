WITH Passwords AS (/*Задаем варианты паролей*/
  SELECT ROWNUM AS ID, Password
  FROM (
    SELECT 'O9gh$drW3' AS Password   FROM dual
    /*Корректный*/
    UNION ALL SELECT 'O9gh$frW3'     FROM dual
    /*Некорректный*/
  )
),
Letters AS (
  SELECT
    ID,
    Password,
    ASCII(LOWER(REGEXP_SUBSTR(Password, '[a-zA-Z]', 1, LEVEL))) AS Letter
    /*получаем численное значение каждой буквы из паролей*/
  FROM Passwords
  CONNECT BY LEVEL <= REGEXP_COUNT(Password, '[a-zA-Z]')
  /*Ограничиваем количество строк количеством букв в пароле*/
    AND PRIOR ID = ID AND PRIOR SYS_GUID() IS NOT NULL
    /*Выставляем буквы по порядку для каждого из паролей*/
),
WrongPasswords AS (
  SELECT DISTINCT ID
  FROM Letters
  WHERE LEVEL = 3
  /*Ставим ограничение, чтобы не было 3 подряд идущих буквы*/
  CONNECT BY PRIOR ID = ID /*Ограничение для группы*/
    AND PRIOR Letter + 1 = Letter /*Смотрим последовательные буквы в алфавите*/
)
SELECT
  NVL(Password, ' ') AS "Пароль",
  CASE
    WHEN ID IN (SELECT ID FROM WrongPasswords)
    THEN 'Некорректный'
    ELSE 'Корректный'
    /*Ставим корректность, если нет в списке неверных паролей*/
  END AS "Корректность"
FROM Passwords;
