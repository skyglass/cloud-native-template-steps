
export PORTABLE_SED_COMMAND

if [[ $OSTYPE == 'darwin'* ]]; then
    PORTABLE_SED_COMMAND=(sed -i '')
else
    PORTABLE_SED_COMMAND=(sed -i)
fi
