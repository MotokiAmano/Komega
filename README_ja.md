<a name= "japanese">
日本語 / [English](README.md#english)

# What ? 

Shifted-Krylov部分空間法に基づくソルバーライブラリと,
それを用いてHamiltonianと励起状態ベクトルから動的Green関数を計算するミニアプリである.

# [Download](https://github.com/issp-center-dev/Komega/releases)

最新版のパッケージはこちらから.


リリースノート


# Prerequisite

 * fortranコンパイラ
 * BLASライブラリ
 * LAPACKライブラリ
 * MPIライブラリ(Optional)
 
# Documents

 * Manual for the Library
   * Japanese ([HTML](https://issp-center-dev.github.io/Komega/library/ja/_build/html/index.html)/[PDF](https://issp-center-dev.github.io/Komega/library/ja/_build/latex/komega.pdf))
   * English ([HTML](https://issp-center-dev.github.io/Komega/library/en/_build/html/index.html)/[PDF](https://issp-center-dev.github.io/Komega/library/en/_build/latex/komega.pdf))
 * Manual for the sample program
   * Japanese ([HTML](https://issp-center-dev.github.io/Komega/software/ja/_build/html/index.html)/[PDF](https://issp-center-dev.github.io/Komega/software/ja/_build/latex/shiftk.pdf))
   * English ([HTML](https://issp-center-dev.github.io/Komega/software/en/_build/html/index.html)/[PDF](https://issp-center-dev.github.io/Komega/software/en/_build/latex/shiftk.pdf))

# Directory Tree

 * `app/`: ミニアプリ関連のディレクトリ
   * `src/`: ミニアプリソースコードのディレクトリ
   * `sample/`: ミニアプリサンプル用ディレクトリ
     * `Shiftk.nb`: テスト用Mathematicaノートブック(開発者向け)
     * `denovo/`: ハミルトニアンや右辺ベクトルの入力ファイルを用いない場合の例
     * `from_file/`: ハミルトニアンや右辺ベクトルの入力ファイルを用いる場合の例
 * `doc/`: ドキュメント用ディレクトリ
   * `index.html` : ドキュメントのトップページ
   * `library/`: ライブラリのドキュメントのディレクトリ
   * `software/`: ミニアプリのドキュメントのディレクトリ
 * `make.sys`: ビルド環境指定ファイル
 * `makefile`: Makeファイル
 * `src/`: ライブラリ本体のディレクトリ
   * `mpi/`: MPI版ライブラリのディレクトリ
   * `shared/`: 動的ライブラリのディレクトリ
   * `shared_mpi/`: MPI版動的ライブラリのディレクトリ
 * `test/`: ライブラリのテスト用ディレクトリ

# Build

 * 必要に応じて`make.sys`を編集する.
   * `F90`:fortranコンパイルコマンド
   * `FFLAGS`: オプション.BLASのリンク(`-lblas`や`-mkl`)など.
   * `MPIF90`:MPI版fortranコンパイルコマンド. MPI版が必要ない場合には指定しなくて良い.
 * `$ make`

以下のものが作られる.

 * `src/libkomega.a` : シリアル版静的ライブラリ
 * `src/shared/libkomega.so` : シリアル版動的ライブラリ
 * `src/mpi/libpkomega.a` : MPI版静的ライブラリ(Optional)
 * `src/shared_mpi/libpkomega.so` : MPI版動的ライブラリ(Optional)
 * `app/src/Shiftk.out` : ミニアプリ
 * `app/src/mpi/Shiftk.out` : MPI版ミニアプリ (Oprional)

# ミニアプリのテスト

 * `app/sample/denovo/`もしくは`app/sample/from_file/`ディレクトリに移動する.
 * `$ ../../src/ShiftK.out namelist.def`とやる.
 * `dynamicalG.dat`などが作られると成功.
 * `namelist.def`の書式はマニュアル参照

# ライブラリの使用方法

## プログラム内での各ルーチンの呼び出し方

### fortran/C/C++の場合

マニュアル参照(作成中)

## ライブラリのリンク方法

静的リンク
``` bash
$ gfortran myprog.f90 -L パス/src -lshiftk -I パス/src
$ gcc myprog.f90 -L パス/src -lshiftk -I パス/src
```
など.

動的リンク
``` bash
$ gfortran myprog.f90 -L パス/src/shared -lshiftk -I パス/src/shared
$ gcc myprog.f90 -L パス/src/shared -lshiftk -I パス/src/shared
```
など.

動的リンクを行ったファイルを実行するときには,
環境変数`LD_LIBRARY_PATH`に`src/shared`ディレクトリを追加しておく必要がある.

### C/C++の場合

# ライブラリのテスト(Optional)

 * `test/`ディレクトリに移動する.
 * `$ ./solve_cc.x < krylov.in`とやる.
 * Residual vectorが十分小さくなっていれば成功
 * `solve_rc.x`なども同様
 * `krylov.in`(名称は自由)のパラメーターは次の通り
   * `ndim`: 擬似ハミルトニアンの次元
   * `nl`: 射影のテスト用. 解ベクトルの先頭から`nl(<=ndim)`番目までを計算する.
   * `nz`: 振動数の点数
   * `itermax`: 最大反復回数
   * `threshold`: 収束判定のthreshold
   * `rnd_seed`: 擬似Hamiltonian生成のための乱数の種
   * このnamelistの後ろに振動数を1行に1個ずつ書く.
     