if su postgres -c "psql -d $1 -c '\dt' | grep \"No relations found\"" > /dev/null 2>&1
    then echo "1"
    else echo "0"
fi
