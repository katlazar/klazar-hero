// Unused usings removed
using System.IO;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.EntityFrameworkCore;
using HeroesApi.Models;
using Microsoft.Extensions.FileProviders;

using System.Text;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using Microsoft.IdentityModel.Logging;
using Microsoft.AspNetCore.Authentication;
using System.Linq;


namespace HeroesApi
{
    public class Startup
    {
        private const string Name = "_myAllowSpecificOrigins";
        public Startup(IConfiguration configuration)
        {
            Configuration = configuration;
        }

        public IConfiguration Configuration { get; }

        // This method gets called by the runtime. Use this method to add services to the container.
        public void ConfigureServices(IServiceCollection services)
        {
            services.AddDbContext<HeroContext>(opt =>
               opt.UseInMemoryDatabase("HeroesList"));

            services.AddCors(options =>
            {
                options.AddPolicy(Name, 
                    builder =>
                    {
                        // AllowAnyMethod needed for PUT request when changing hero name
                        builder.WithOrigins("http://localhost:80")
                            .AllowAnyHeader()
                            .AllowAnyMethod()
                            .AllowCredentials();
                    });
            });

            
            var appSettingsSection = Configuration.GetSection("AppSettings");
            services.Configure<AppSettings>(appSettingsSection);

            IdentityModelEventSource.ShowPII = true;

            // configure jwt authentication
            var appSettings = appSettingsSection.Get<AppSettings>();
            var key = Encoding.UTF8.GetBytes(appSettings.SecretKey);
            var audience = appSettings.Audience;
            
            services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
                .AddJwtBearer(options =>
                {
                    options.SaveToken = true;
                    options.TokenValidationParameters = new TokenValidationParameters
                    {
                        ValidateIssuer = true, 
                        ValidateAudience = true, 
                        ValidateIssuerSigningKey = true,
                        IssuerSigningKey = new SymmetricSecurityKey(key),
                        AudienceValidator = (audiences, securityToken, validationParameters) =>
                        {
                            return audiences.Contains(audience);
                        },
                        IssuerValidator = (issuer, securityToken, validationParameters) =>
                        {
                            if (issuer.Equals("dtpoland.com"))
                                return issuer;
                            else
                                throw new SecurityTokenInvalidIssuerException("Wrong issuer");
                        }
                    };
                });
            services.AddControllers();
        }

        // This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
        public void Configure(IApplicationBuilder app, IWebHostEnvironment env)
        {
            if (env.IsDevelopment())
            {
                app.UseDeveloperExceptionPage();
            }
            app.UseHttpsRedirection();
            app.UseRouting();
            app.UseAuthentication();
            app.UseAuthorization();
	        app.UseFileServer(new FileServerOptions
            {
                FileProvider = new PhysicalFileProvider(
                  Path.Combine(Directory.GetCurrentDirectory(), "AngularApp")),
                RequestPath = "",

            });		
            DefaultFilesOptions options = new DefaultFilesOptions();
            options.DefaultFileNames.Clear();
            
            app.UseDefaultFiles(options);
            app.UseStaticFiles();  
            app.UseCors(Name); 

            app.UseEndpoints(endpoints =>
            {
                endpoints.MapControllers();
            });
            
        }
            private void SetAuthenticationOptions(AuthenticationOptions authenticationOptions)
        {
            authenticationOptions.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
            authenticationOptions.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
        }

        private class AppSettings
        {
            public string SecretKey { get; set; }
            public string Audience { get; set; }
        }
    }
}

