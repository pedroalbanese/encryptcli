# EncryptCLI
Command-line File Encryption Tool written in AutoIt3

<pre>
Usage: 
   EncryptCLI.exe -e|d --in &lt;file.ext&gt; --alg &lt;algorithm&gt; --psw &lt;password&gt;

Commands: 
   -e: Encrypt 
   -d: Decrypt

Parameters: 
   /alg: Algorithm
   /in : Input file
   /out: Output file (Optional [*])
   /psw: Password

   [*] If no output is specified, the input file will be overwritten.

Algorithms:
   3DES, AES-128 (Default), AES-192, AES-256, DES, RC2, RC4
</pre>

## License
This project is licensed under the ISC License.
