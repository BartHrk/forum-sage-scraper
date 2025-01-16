import { zodResolver } from "@hookform/resolvers/zod";
import { useForm } from "react-hook-form";
import { useToast } from "@/components/ui/use-toast";
import { Button } from "@/components/ui/button";
import {
  Form,
  FormControl,
  FormDescription,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from "@/components/ui/form";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import * as z from "zod";
import { useState } from "react";

// Form validation schema
const formSchema = z.object({
  webpageUrl: z.string().url({ message: "Please enter a valid URL" }),
  prompt: z.string().min(10, { message: "Prompt must be at least 10 characters" }),
});

const Index = () => {
  const { toast } = useToast();
  const [isProcessing, setIsProcessing] = useState(false);

  // Initialize form
  const form = useForm<z.infer<typeof formSchema>>({
    resolver: zodResolver(formSchema),
    defaultValues: {
      webpageUrl: "",
      prompt: "",
    },
  });

  const onSubmit = async (values: z.infer<typeof formSchema>) => {
    setIsProcessing(true);
    try {
      // Send request to Ollama server
      const response = await fetch('http://localhost:11434/api/generate', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          model: "huihui_ai/command-r7b-abliterated",
          prompt: `URL: ${values.webpageUrl}\nTask: ${values.prompt}`,
          stream: false
        }),
      });

      if (!response.ok) {
        throw new Error('Failed to process request');
      }

      const data = await response.json();
      
      toast({
        title: "Processing Complete",
        description: "The webpage has been processed successfully.",
      });
      
      console.log("Ollama response:", data);
      
    } catch (error) {
      toast({
        variant: "destructive",
        title: "Error",
        description: "Failed to process the webpage. Please try again.",
      });
      console.error("Error:", error);
    } finally {
      setIsProcessing(false);
    }
  };

  return (
    <div className="container mx-auto p-6 max-w-2xl">
      <div className="space-y-6">
        <div className="space-y-2">
          <h1 className="text-3xl font-bold">Web Crawler Interface</h1>
          <p className="text-gray-500">
            Enter a webpage URL and specify your task for the LLM to process.
          </p>
        </div>

        <Form {...form}>
          <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-6">
            <FormField
              control={form.control}
              name="webpageUrl"
              render={({ field }) => (
                <FormItem>
                  <FormLabel>Webpage URL</FormLabel>
                  <FormControl>
                    <Input placeholder="https://example.com" {...field} />
                  </FormControl>
                  <FormDescription>
                    Enter the full URL of the webpage you want to process.
                  </FormDescription>
                  <FormMessage />
                </FormItem>
              )}
            />

            <FormField
              control={form.control}
              name="prompt"
              render={({ field }) => (
                <FormItem>
                  <FormLabel>Task Prompt</FormLabel>
                  <FormControl>
                    <Textarea
                      placeholder="Extract all article titles and their publication dates..."
                      className="min-h-[100px]"
                      {...field}
                    />
                  </FormControl>
                  <FormDescription>
                    Describe what information you want to extract from the webpage.
                  </FormDescription>
                  <FormMessage />
                </FormItem>
              )}
            />

            <Button type="submit" disabled={isProcessing}>
              {isProcessing ? "Processing..." : "Process Webpage"}
            </Button>
          </form>
        </Form>
      </div>
    </div>
  );
};

export default Index;