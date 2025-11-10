using MailKit.Net.Smtp;
using MailKit.Security;
using MimeKit;

namespace Backend.Services;

public class MailKitEmailSender(IConfiguration configuration) : IEmailSender
{
    public async Task SendEmailAsync(string toEmail, string subject, string body)
    {
        var message = new MimeMessage();
        message.From.Add(MailboxAddress.Parse(configuration["Smtp:From"]));
        message.To.Add(MailboxAddress.Parse(toEmail));
        message.Subject = subject;
        message.Body = new TextPart("plain") { Text = body };

        using var client = new SmtpClient();
        
        var host = configuration["Smtp:Host"];
        var port = int.Parse(configuration["Smtp:Port"] ?? "587");
        var useSsl = configuration.GetValue<bool>("Smtp:UseSsl", true);
        
        await client.ConnectAsync(host, port, useSsl ? SecureSocketOptions.StartTls : SecureSocketOptions.None);
        
        var username = configuration["Smtp:Username"];
        var password = configuration["Smtp:Password"];
        
        if (!string.IsNullOrEmpty(username) && !string.IsNullOrEmpty(password))
        {
            await client.AuthenticateAsync(username, password);
        }
        
        await client.SendAsync(message);
        await client.DisconnectAsync(true);
    }
}

