import { zodResolver } from "@hookform/resolvers/zod";
import { useForm } from "react-hook-form";
import { useToast } from "@/hooks/use-toast";
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

const formSchema = z.object({
  webpageUrl: z.string().url({ message: "Please enter a valid URL" }),
  prompt: z.string().min(10, { message: "Prompt must be at least 10 characters" }),
  outputFile: z.string().min(1, { message: "Please specify an output file path" }),
});

const Index = () => {
  const { toast } = useToast();
  const [isProcessing, setIsProcessing] = useState(false);

  const form = useForm<z.infer<typeof formSchema>>({
    resolver: zodResolver(formSchema),
    defaultValues: {
      webpageUrl: "",
      prompt: "",
      outputFile: "/var/log/ollama/results.txt",
    },
  });

  const onSubmit = async (values: z.infer<typeof formSchema>) => {
    setIsProcessing(true);
    try {
      // First, generate the response from Ollama
      const ollamaResponse = await fetch('/api/generate', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          model: "llama2",
          prompt: `URL: ${values.webpageUrl}\nTask: ${values.prompt}`,
          stream: false
        }),
      });

      if (!ollamaResponse.ok) {
        throw new Error('Failed to get response from Ollama');
      }

      const ollamaData = await ollamaResponse.json();
      
      // Then, write the results to the specified file
      const writeResponse = await fetch('/api/write', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          filePath: values.outputFile,
          content: ollamaData.response
        }),
      });

      if (!writeResponse.ok) {
        throw new Error('Failed to write results to file');
      }

      toast({
        title: "Success",
        description: `Results have been saved to ${values.outputFile}`,
      });
      
      console.log("Processing complete:", ollamaData);
      
    } catch (error) {
      console.error("Error details:", error);
      toast({
        variant: "destructive",
        title: "Error",
        description: error instanceof Error ? error.message : "Failed to process the webpage. Please try again.",
      });
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

            <FormField
              control={form.control}
              name="outputFile"
              render={({ field }) => (
                <FormItem>
                  <FormLabel>Output File Path</FormLabel>
                  <FormControl>
                    <Input 
                      placeholder="/var/log/ollama/results.txt" 
                      {...field} 
                    />
                  </FormControl>
                  <FormDescription>
                    Specify where to save the results.
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