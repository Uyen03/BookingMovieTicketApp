using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Backend.Extention
{
    public class Utils
    {
        public static string DB_MYSQL
        {
            get
            {
                try
                {
                    return "Server=localhost;User=root;Password=123456;Database=movieticket;Port=3306";
                   
                }
                catch
                {
                    Console.WriteLine("Can't get DB_MYSQL!");
                }
                return string.Empty;
            }
        }
    }
}