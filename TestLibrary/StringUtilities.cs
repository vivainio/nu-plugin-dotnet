using System;
using System.Linq;
using System.Text;

namespace TestLibrary
{
    /// <summary>
    /// A custom utility class with string operations for testing
    /// </summary>
    public static class StringUtilities
    {
        /// <summary>
        /// Reverses a string
        /// </summary>
        /// <param name="input">The string to reverse</param>
        /// <returns>The reversed string</returns>
        public static string Reverse(string input)
        {
            if (string.IsNullOrEmpty(input))
                return input;
            
            return new string(input.Reverse().ToArray());
        }

        /// <summary>
        /// Checks if a string is a palindrome
        /// </summary>
        /// <param name="input">The string to check</param>
        /// <returns>True if the string is a palindrome, false otherwise</returns>
        public static bool IsPalindrome(string input)
        {
            if (string.IsNullOrEmpty(input))
                return true;
            
            string normalized = input.ToLowerInvariant().Replace(" ", "");
            return normalized == Reverse(normalized);
        }

        /// <summary>
        /// Counts the number of words in a string
        /// </summary>
        /// <param name="input">The string to count words in</param>
        /// <returns>The number of words</returns>
        public static int WordCount(string input)
        {
            if (string.IsNullOrWhiteSpace(input))
                return 0;
            
            return input.Split(new char[] { ' ', '\t', '\n', '\r' }, 
                StringSplitOptions.RemoveEmptyEntries).Length;
        }

        /// <summary>
        /// Converts a string to title case
        /// </summary>
        /// <param name="input">The string to convert</param>
        /// <returns>The string in title case</returns>
        public static string ToTitleCase(string input)
        {
            if (string.IsNullOrEmpty(input))
                return input;
            
            var words = input.ToLowerInvariant().Split(' ');
            var result = new StringBuilder();
            
            foreach (var word in words)
            {
                if (word.Length > 0)
                {
                    result.Append(char.ToUpperInvariant(word[0]));
                    if (word.Length > 1)
                        result.Append(word.Substring(1));
                    result.Append(' ');
                }
            }
            
            return result.ToString().TrimEnd();
        }

        /// <summary>
        /// Generates a simple hash code for a string
        /// </summary>
        /// <param name="input">The string to hash</param>
        /// <returns>A simple hash code</returns>
        public static int SimpleHash(string input)
        {
            if (string.IsNullOrEmpty(input))
                return 0;
            
            int hash = 0;
            foreach (char c in input)
            {
                hash = (hash * 31) + c;
            }
            
            return hash;
        }
    }
} 