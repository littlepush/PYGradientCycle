# Gradient Cycle in iOS

I'm not sure if this is the best solution.

![Preview](https://raw.githubusercontent.com/littlepush/PYGradientCycle/master/cycle.gif)

Now I use a cached `CGContextRef` to improve the CPU usage.

To draw an increase percentage animation, the CPU is no more than 25%, but the decrease animation still sucks.

