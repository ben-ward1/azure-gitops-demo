using System.Diagnostics;
using Microsoft.AspNetCore.Mvc;
using azure_gitops_demo.Models;
using Microsoft.Data.SqlClient;

namespace azure_gitops_demo.Controllers;

public class HomeController : Controller
{
    private readonly ILogger<HomeController> _logger;
    private readonly IConfiguration _config;

    public HomeController(ILogger<HomeController> logger, IConfiguration config)
    {
        _logger = logger;
        _config = config;
    }

    public IActionResult Index()
    {
        var connectionString = _config["sqlConnectionString"];
        bool connected;

        using (var sqlConnection = new SqlConnection(connectionString))
        {
            try
            {
                sqlConnection.Open();
                connected = true;
            }
            catch (SqlException e)
            {
                connected = false;
            }
        }

        ViewData["connected"] = connected;

        return View();
    }

    public IActionResult Privacy()
    {
        return View();
    }

    [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
    public IActionResult Error()
    {
        return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
    }
}
