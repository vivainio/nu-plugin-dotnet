using System;

namespace TestLibrary
{
    /// <summary>
    /// A custom utility class with mathematical operations for testing
    /// </summary>
    public static class MathUtilities
    {
        /// <summary>
        /// Calculates the factorial of a number
        /// </summary>
        /// <param name="n">The number to calculate factorial for</param>
        /// <returns>The factorial result</returns>
        public static long Factorial(int n)
        {
            if (n < 0)
                throw new ArgumentException("Factorial is not defined for negative numbers");
            
            if (n == 0 || n == 1)
                return 1;
            
            long result = 1;
            for (int i = 2; i <= n; i++)
            {
                result *= i;
            }
            return result;
        }

        /// <summary>
        /// Checks if a number is prime
        /// </summary>
        /// <param name="number">The number to check</param>
        /// <returns>True if the number is prime, false otherwise</returns>
        public static bool IsPrime(int number)
        {
            if (number <= 1)
                return false;
            
            if (number <= 3)
                return true;
            
            if (number % 2 == 0 || number % 3 == 0)
                return false;
            
            for (int i = 5; i * i <= number; i += 6)
            {
                if (number % i == 0 || number % (i + 2) == 0)
                    return false;
            }
            
            return true;
        }

        /// <summary>
        /// Calculates the greatest common divisor of two numbers
        /// </summary>
        /// <param name="a">First number</param>
        /// <param name="b">Second number</param>
        /// <returns>The GCD of the two numbers</returns>
        public static int GreatestCommonDivisor(int a, int b)
        {
            a = Math.Abs(a);
            b = Math.Abs(b);
            
            while (b != 0)
            {
                int temp = b;
                b = a % b;
                a = temp;
            }
            
            return a;
        }

        /// <summary>
        /// Calculates the Fibonacci sequence up to n terms
        /// </summary>
        /// <param name="n">Number of terms</param>
        /// <returns>Array containing the Fibonacci sequence</returns>
        public static long[] Fibonacci(int n)
        {
            if (n <= 0)
                return Array.Empty<long>();
            
            if (n == 1)
                return new long[] { 0 };
            
            long[] fib = new long[n];
            fib[0] = 0;
            fib[1] = 1;
            
            for (int i = 2; i < n; i++)
            {
                fib[i] = fib[i - 1] + fib[i - 2];
            }
            
            return fib;
        }
    }
} 