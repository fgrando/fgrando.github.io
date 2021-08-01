---
layout: post
title:  "Measuring elapsed time"
date:   2020-06-24 20:36:55 -0300
categories: cpp software sw
author: fgrando
---
{% assign data = "/assets/2020-06-24-elapsed_time_measurement.data/" %}

Measuring time using C++ 11

{% highlight cpp %}
#include <chrono>

std::chrono::steady_clock::time_point begin = std::chrono::steady_clock::now();

cout << "put busy operation here" << endl;

std::chrono::steady_clock::time_point end = std::chrono::steady_clock::now();
std::cout << "elapsed: "
            << std::chrono::duration_cast<std::chrono::nanoseconds> (end - begin).count()
            << " ns" << std::endl;

{% endhighlight %}

