---
categories:
- Tutorials
date: '2013-09-09'
id: 54
slug: the-undocumented-potential-matlabs-java-foundation-generating-hmac-hashes
tags:
- coding
- hashing
- matlab
title: 'The undocumented potential MATLAB’s Java foundation: Generating HMAC Hashes'

---

MATLAB is a widely used programming language in the field of research and development of algorithms and during my studies in Auditory Technology and Audiology the curriculum puts a considerable emphasis on learning how to produce code in MATLAB. By now I&#8217;d call myself a fairly good programmer in MATLAB and I really enjoy working with it. MATLAB is perfect for working with matrices and solving numerical problems. It is an interpreted language, easy to read and while it is only available commercially, I tend to see advantages in the fact that it is a proprietary product. For example I am certain that only the fewest of other programming language are provided with such a detailed, consistent, and omnipotent documentation for the available functions as the one issued by [The MathWorks](http://www.mathworks.com/).

However a huge portion of the capabilities of MATLAB remains undocumented almost handled as a secret, thus it is a widely known fact, that the MATLAB provide easy and direct access to the Java environment of the operating system. Sure, the function library provides a few interfaces to access Java objects and import classes etc. But perhaps due to the sheer size of the Java universe, the documentation does not go much further than that.

<!--more-->

Which leads me to the occasion of this article and the following little step-by-step tutorial. In a current project I am working on, I am building the direct MATLAB interface to an audio database to provide easy access to audio test material during research. The authentication is now supposed to be protected against eavesdropping and man-in-the-middle attacks and based on challenge/response authentication CRAM-MD5 after [RFC2195](http://www.ietf.org/rfc/rfc2195). Therefore I need my database interface function to generate a [Keyed-MD5](https://en.wikipedia.org/wiki/Hash-based_message_authentication_code), or “Hashed Message Authentication Code” (HMAC) digest of the challenge for the response.

Using a MEX function would do the trick and there are various C-code implementations of HMAC-MD5 available on the web. Still I’d have to create a MEX wrapper to the C-code and unbundle the HMAC algorithm from all the adjacent code in all the implementations. So I looked into using the Java Foundation and its strong codebase in the security and encryption area. Eureka. I got the complete authentication working in a few hours, without tedious rewrites of C functions, but with only about 10 lines for the plain implementation..

A few hours seems fairly long considering the 10 lines, doesn’t it? But diving into the matter took quite a while, since I am completely new to working with Java, not only from within MATLAB. But I learned a little thing about it and because I am a nice guy and want to give back to the community, I figured I&#8217;d write this little how-to for this particular problem: generating a Keyed-MD5/HMAC-MD5 hashsum/digest generator in MATLAB using the [`javax.crypto.Mac`](http://docs.oracle.com/javase/1.4.2/docs/api/javax/crypto/Mac.html) class. Let’s dig right in:

  1. Like in any real Java function you’d first have to import classes. With that, the methods of said classes become available in the namespace of the function, making its calls a little more convenient.
    <pre><code class="matlab">import javax.crypto.spec.SecretKeySpec;
import javax.crypto.Mac;
</code></pre>

  2. The Keyed-MD5 algorithm is using a secret key (i.e. a password) to hash a given data string. Since simply loading MATLAB char arrays can not always simply be an input to a Java function, and the future Java Key Object carrying the password is one of those, we generate Java String objects from the MATLAB char arrays containing the password `szPass` and data `szData`.
    <pre><code class="matlab">joStrPass = javaObject('java.lang.String',uint8(szPass));
joStrData = javaObject('java.lang.String',uint8(szData));
</code></pre>

    (If you are using a MATLAB release prior to R2013b, please consider the [update at the bottom of this post](#update1))

  3. `javaObject();` is actually a MATLAB-internal function and is well described in the documentation. It invokes the constructor if a Java class and returns an new object to said class. Everything beyond the first input argument is passed on to the constructor, in this case resulting in a string object filled with either password or data. Next we’ll convert the Java string object of the password into a key object:

    <pre><code class="matlab">joKeyPass = SecretKeySpec(joStrPass.getBytes('UTF-8'), 'HmacMD5');
</code></pre>

    This is necessary, since the HMAC algorithm requires this to be properly initiated. `joStrPass` is passed along with its method `.getBytes();`, issuing the string converted to byte (8-bit) values, being parsed as UTF-8 characters. At this point in time it is important to note the documentation of Java. Sure, the docs of MATLAB are highly detailed, easy to understand, and provide a lot of examples. But like most programming languages, Java has basic class specifications written-out. To find those, a simple websearch on the class&#8217;es name or method does suffice. The [details on the SecretKeySpec](http://docs.oracle.com/javase/6/docs/api/javax/crypto/spec/SecretKeySpec.html#SecretKeySpec%28byte[],%20int,%20int,%20java.lang.String%29), for example, inform us that “the contents of the array are copied to protect against subsequent modification”.

  4. Now it is time to get to the hashing algorithm itself, first constructing it and then initializing it with the formerly created key object:

    <pre><code class="matlab">joHmacAlgo = Mac.getInstance('HmacMD5');
joHmacAlgo.init(joKeyPass);
</code></pre>

    As you see along the way, quite different from MATLAB, Java being object-oriented leads to a heavy use of constructors and initializations. Every object has to be properly loaded before being ready for use. MATLAB does support object-oriented programming, too. But it is not very widely used yet, despite its advantages. Thus most MATLAB users will not be used to initializations etc.

  5. Anyways, we are at the final lines of our implementation and about to use the only MATLAB functions in this implementation to complete the output. The Algorithm is now fed with the data string object, being parsed byte-wise as ASCII (note the difference to parsing the password as UTF-8).

    <pre><code class="matlab">joByteHash = joHmacAlgo.doFinal(strObj_Data.getBytes('ASCII'));
% Re-cast the hash into MATLAB hex formatted char array:
szDigest = lower(reshape(dec2hex(typecast(joByteHash,'uint8'))',1,[]));
</code></pre>

    So the last line first typecasts the Java bytes object (issued by the HMAC algorithm) into an 8-bit unsigned integer MATLAB array. Thus we’re back in a MATLAB type. Now, uint8 is the perfect type to be finally converted into a hex string. Unfortunately the output is shaped weirdly in a 16&#215;2-char array. Therefore we need to transpose the array and reshape it, resulting in the commonly known 32-char array. A little preference of mine is to convert the letters in the hex string to be lowercase, using `lower();`.

For me, the conclusion is quite obvious: hauling Java into the MATLAB workspace is not too complicated. Many well-known algorithms are implemented in Java classes and can therefore be used in MATLAB, without having to write more than a little handling of data types. But one last word of advice: The Java Foundation is not documented for no reason. It is not supported by The MathWorks and if an update on either MATLAB or the [Java SE](https://en.wikipedia.org/wiki/Java_Platform,_Standard_Edition) breaks your script’s functionality or if the code does not perform equally on every platform, you are on your own. Ultimately using Java from within MATLAB might not be the best way to handle long-term deployment without frequent updating. But maintained code can easily be enhanced with the huge capabilites not only of the general purpose libraries, but also from third-party packages. By the way: The latter are made avaiable with `javaaddpath();` before the `import`-statements from within your MATLAB script:

<pre><code class="matlab">javaaddpath('/path/to/full_package_filename.jar');
</code></pre>

### <a name="update1"></a>Update #1

As Attila made me realize (thank you, pal!), MATLAB does not handle the zero value character (`'\0'`, also called “null terminator”, “NUL”) quite as expected in the MATLAB version I am using (R2012a, releases before that likely are affected, too). Strings containing `'\0'` will be truncated right before that character, somehow making null-termination totally live up to it&#8217;s name in the wrong place. This behavior was changed in future MATLAB releases and as of R2013a, `'\0'` in a char array will be interpreted (correctly) as _one char_, namely code 0 in ASCII, with no truncation taking place. The best work-around in older releases to prevent the truncation and force correct pass-through of NUL is to manually convert the `'\0'`-notation using the following string replacement right after receiving it from an input of some kind:

<pre><code class="matlab">szOutput = strrep(szInput, '\0', char(0));
</code></pre>

As far as this tutorial is concerned an additional minor correction needed to be made: for robust handling of the NUL char `szPass` and `szData` need to be converted into 8-bit unsigned integer elements before creating their respective Java Objects. The revision is also included in the code block in step 2.