
install_requirements :-
        ensure_loaded(pack),
        Opts=[interactive(false)],
        requires(X),
        pack_install(X, Opts),
        fail.
install_requirements.
    