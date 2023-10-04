#!/bin/bash

password_file="passwords.txt"
encrypted_file="passwords.txt.gpg"

while true; do
    echo "パスワードマネージャーへようこそ！"
    echo "次の選択肢から入力してください(Add Password/Get Password/Exit)："
    read choice

    if [ "$choice" == "Add Password" ]; then
        echo "サービス名を入力してください："
        read service
        echo "ユーザー名を入力してください："
        read username
        echo "パスワードを入力してください："
        read password

        # 復号化
        gpg --output $password_file --decrypt $encrypted_file 2>/dev/null

        echo "$service:$username:$password" >> $password_file
        echo "パスワードの追加は成功しました。"

        # 暗号化
        gpg --yes --batch --passphrase="YOUR_PASSPHRASE" -c $password_file
        rm $password_file

    elif [ "$choice" == "Get Password" ]; then
        echo "サービス名を入力してください："
        read service

        # 復号化して一時ファイルに保存
        gpg --output $password_file --decrypt $encrypted_file 2>/dev/null

        found=0
        while IFS= read -r line; do
            if echo "$line" | grep -q "^$service:"; then
                serv=$(echo $line | cut -d':' -f1)
                user=$(echo $line | cut -d':' -f2)
                pass=$(echo $line | cut -d':' -f3)

                echo "サービス名：$serv"
                echo "ユーザー名：$user"
                echo "パスワード：$pass"
                found=1
            fi
        done < $password_file

        if [ "$found" -eq 0 ]; then
            echo "そのサービスは登録されていません。"
        fi

        rm $password_file

    elif [ "$choice" == "Exit" ]; then
        echo "Thank you!"
        exit 0

    else
        echo "入力が間違えています。Add Password/Get Password/Exit から入力してください。"
    fi
done

