---
layout: post
title:  "UnitTest in Visual Studio (Native Unit Test Project)"
date:   2020-06-13 19:12:16 -0300
categories: cpp unittest test visualstudio
author: fgrando
---
{% assign data = "/assets/2020-06-13-unittest_visualstudio.data/" %}

Example of unit test project features in Visual Studio 2013.

Snippet example:

{% highlight c++ %}
#include "stdafx.h"
#include "CppUnitTest.h"

using namespace Microsoft::VisualStudio::CppUnitTestFramework;

namespace UnitTestExample
{
    // Show test window at menu: TEST > Windows > Test Explorer
    TEST_CLASS(UnitTestExample)
    {
    public:

        // There are configurations of priority or playlists
        // but the most effective I found is to enforce
        // the execution order by the test names:

        TEST_METHOD(UT001_FIRST)
        {
            Logger::WriteMessage("This will go to 'Output' section");
        }

        TEST_METHOD(UT002_SECOND)
        {
            Assert::IsTrue(true, L"Message printed when it fails", LINE_INFO());
        }


        TEST_METHOD(UT003_AAAAA)
        {
            std::wstringstream buff;
            buff << "Nice message" << " with variables " << 123;
            Logger::WriteMessage(buff.str().c_str());

            Assert::AreNotEqual(true, false, buff.str().c_str(), LINE_INFO());
        }
    };
}
{% endhighlight %}


![VisualStudio]({{ data }}unittest.png)


Source files [here][unittest-zip]


[unittest-zip]: {{ data }}UnitTest1.zip
