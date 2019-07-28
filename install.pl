
install_requirements :-
        writeln(loading),
        ensure_loaded(pack),
        Opts=[interactive(false)],
        requires(X),
        writeln(installing(X)),
        pack_install(X, Opts),
        fail.
install_requirements.


install_this :-
        Opts=[interactive(false)],
        install_requirements,
        name(X),
        pack_install(X,Opts).
